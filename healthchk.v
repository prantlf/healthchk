import net.http { Method, Request, Response }
import os
import strconv { atoi }
import time { sleep, ticks }

struct Opts {
mut:
	url       string
	method    Method = .get
	timeout   int    = 30
	redirects bool   = true
	silent    bool
	verbose   bool
}

const version = '0.1.0'

const help = 'usage: healthchk [option ...] <url>
options:
  -m <method>   HTTP method to use (default: GET)
  -t <seconds>  connection timeout (default: 30 seconds)
  -R            disallow redirects (default: allowed)
  -s            print nothing on success (default: no)
  -v            print the response body too (default: no)
  -V            print version number and exit
  -h            print usage instructions and exit'

@[direct_array_access]
fn starts_with_u8(s string, c u8) bool {
	return s.len > 0 && s[0] == c
}

@[direct_array_access]
fn init(mut opts Opts) ! {
	cnt := os.args.len
	for i := 1; i < cnt; i++ {
		mut arg := os.args[i]
		match arg {
			'-m' {
				i++
				if i == os.args.len {
					return error('missing HTTP method')
				}
				arg = os.args[i]
				opts.method = Method.from(arg.to_lower()) or {
					return error('invalid HTTP method: ${arg}')
				}
			}
			'-t' {
				i++
				if i == os.args.len {
					return error('missing timeout duration')
				}
				arg = os.args[i]
				opts.timeout = atoi(arg) or { return error('invalid timeout duration: ${arg}') }
			}
			'-R' {
				opts.redirects = false
			}
			'-s' {
				opts.silent = true
			}
			'-v' {
				opts.verbose = true
			}
			'-V' {
				println(version)
				exit(0)
			}
			'-h' {
				println(help)
				exit(0)
			}
			else {
				if starts_with_u8(arg, `-`) {
					return error('unknown argument: ${arg}')
				}
				if opts.url.len > 0 {
					return error('more than one URL found: ${arg}')
				}
				opts.url = arg
			}
		}
	}
}

fn fail(err IError) {
	text := err.msg()
	if text.len > 0 {
		println('error: ${text}')
	}
	exit(1)
}

fn check(opts &Opts, back chan &Response) {
	mut req := Request{
		method:         opts.method
		url:            opts.url
		allow_redirect: opts.redirects
	}
	res := req.do() or {
		fail(err)
		return
	}
	back <- &res
}

fn wait(opts &Opts, back chan bool) {
	sleep(opts.timeout * time.second)
	back <- true
}

fn eval(opts &Opts, res &Response, duration i64) ! {
	failed := res.status_code >= 400
	if failed || !opts.silent {
		typ := res.header.get(.content_type) or { 'not available' }
		unit := if res.body.len == 1 {
			'byte'
		} else {
			'bytes'
		}
		println('status: ${res.status_code}, type: ${typ}, size: ${res.body.len} ${unit}, duration: ${duration} ms')
	}
	if (failed || opts.verbose) && res.body.len > 0 {
		println(res.body)
	}
	if failed {
		return error('')
	}
}

fn run() ! {
	if os.args.len < 2 {
		println(help)
		return error('missing URL')
	}
	mut opts := &Opts{}
	init(mut opts)!
	res_check := chan &Response{}
	spawn check(opts, res_check)
	res_wait := chan bool{}
	spawn wait(opts, res_wait)
	mut waiting := true
	start := ticks()
	select {
		res := <-res_check {
			waiting = false
			finish := ticks()
			eval(opts, res, finish - start)!
		}
		_ := <-res_wait {
			if waiting {
				return error('timed out')
			}
		}
	}
}

fn main() {
	run() or { fail(err) }
}
