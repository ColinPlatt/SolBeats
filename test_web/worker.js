importScripts('https://binaries.soliditylang.org/bin/soljson-v0.8.19+commit.7dd6d404.js')
import wrapper from 'solc/wrapper';

self.addEventListener('message', () => {
	const compiler = wrapper(self.Module)
	self.postMessage({
		version: compiler.version()
	})
}, false)