#!/usr/bin/env python3
"""Patch electrumx daemon.py to extract Basic Auth from DAEMON_URL.

aiohttp >= 3.9 no longer supports credentials in URLs (user:pass@host).
This patch modifies the Daemon class to extract credentials from the URL
and pass them via aiohttp.BasicAuth on each request.
"""

import re
import sys

def patch_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Check if already patched
    if 'BasicAuth' in content:
        print(f'{filepath}: already patched, skipping')
        return

    # 1. Add 'from urllib.parse import urlparse' to imports
    content = content.replace(
        'import aiohttp\n',
        'import aiohttp\nfrom urllib.parse import urlparse, urlunparse\n'
    )

    # 2. Add _extract_auth method and modify set_url to store auth
    old_set_url = '''    def set_url(self, url):
        \'\'\'Set the URLS to the given list, and switch to the first one.\'\'\'
        urls = url.split(',')
        urls = [self.coin.sanitize_url(url) for url in urls]
        for n, url in enumerate(urls):'''

    new_set_url = '''    @staticmethod
    def _extract_auth(url):
        """Extract Basic Auth credentials from a URL and return (clean_url, auth).

        aiohttp >= 3.9 no longer supports user:pass@host in URLs.
        """
        parsed = urlparse(url)
        if parsed.username:
            auth = aiohttp.BasicAuth(
                login=parsed.username,
                password=parsed.password or ''
            )
            clean = urlunparse(parsed._replace(
                netloc=parsed.hostname + (f':{parsed.port}' if parsed.port else '')
            ))
            return clean, auth
        return url, None

    def set_url(self, url):
        \'\'\'Set the URLS to the given list, and switch to the first one.\'\'\'
        urls = url.split(',')
        urls = [self.coin.sanitize_url(url) for url in urls]
        self.auths = {}
        for n, url in enumerate(urls):
            clean_url, auth = self._extract_auth(url)
            urls[n] = clean_url
            if auth:
                self.auths[n] = auth'''

    content = content.replace(old_set_url, new_set_url)

    # 3. Add current_auth method after current_url
    old_current_url = '''    def current_url(self):
        '''

    new_current_url = '''    def current_auth(self):
        """Return the auth for the current URL, if any."""
        return self.auths.get(self.url_index)

    def current_url(self):
        '''

    content = content.replace(old_current_url, new_current_url)

    # 4. Patch _post_json to pass auth
    content = content.replace(
        'async with self.session.post(self.current_url(), data=data) as resp:',
        'async with self.session.post(self.current_url(), data=data, auth=self.current_auth()) as resp:'
    )

    # 5. Patch _get_to_file to pass auth
    content = content.replace(
        'async with self.session.get(full_url) as resp:',
        'async with self.session.get(full_url, auth=self.current_auth()) as resp:'
    )

    with open(filepath, 'w') as f:
        f.write(content)

    print(f'{filepath}: patched successfully')

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print(f'Usage: {sys.argv[0]} <path/to/daemon.py>')
        sys.exit(1)
    patch_file(sys.argv[1])
