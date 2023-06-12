importScripts('https://cdn.jsdelivr.net/npm/solc@0.8.19/solc.min.js');

self.onmessage = function(e) {
    const contractCode = e.data.contractCode
    const sourceCode = {
        language: 'Solidity',
        sources: {
            contract: {
                content: contractCode,
            }
        },
        settings: {
            outputSelection: {
                '*': {
                    '*': ['*']
                }
            }
        }
    };

    const compiler = solc.setupMethods(solc);
    console.log(`Solc version: ${compiler.version()}`)

    self.postMessage({
        output: JSON.parse(compiler.compile(JSON.stringify(sourceCode)))
    })
};
