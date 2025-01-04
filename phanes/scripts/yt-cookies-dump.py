from http.cookiejar import MozillaCookieJar

import browser_cookie3

cookiejar = browser_cookie3.firefox(domain_name='youtube.com')
MozillaCookieJar.save(cookiejar, filename='/dev/stdout')