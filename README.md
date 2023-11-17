# Pyodide Code Extension for Quarto HTML Documents

This extension enables an interactive Python code cell powered by [pyodide](https://pyodide.org/en/stable/) in a Quarto HTML document.

> Pyodide is a Python distribution for the browser and Node.js based on WebAssembly.


## Developer Notes

We created the quarto extension for a filter by using: 

```sh
quarto create extension filter
```


## Acknowledgements


For the extension, we greatly appreciated insights from: 

- Pyodide 
  - [Using Pyodide](https://pyodide.org/en/stable/usage/index.html)
- Quarto Extensions
  - [`quarto-ext/shinylive`](https://github.com/quarto-ext/shinylive)
  - [`mcanouil/quarto-elevator`](https://github.com/mcanouil/quarto-elevator)
  - [`shafayetShafee/downloadthis`](https://github.com/shafayetShafee/downloadthis/tree/main)
- Quarto Documentation
  - [Filters Documentation](https://quarto.org/docs/extensions/filters.html)
  - [Lua Development Tips](https://quarto.org/docs/extensions/lua.html)
  - [Lua API](https://quarto.org/docs/extensions/lua-api.html)
- Pandoc Documentation
  - [Example Filters](https://pandoc.org/lua-filters.html#examples)
  - [CodeBlock](https://pandoc.org/lua-filters.html#type-codeblock)
- matplotlib patches
  - [`gzuidhof/starboard-notebook` graphics patch](https://github.com/gzuidhof/starboard-notebook/blob/4127a5991399532f496da225ecc4ffcc27aa5529/packages/starboard-python/src/pyodide/matplotlib.ts)
  - [`jupyterlite/pyodide-kernel` graphics patch](https://github.com/jupyterlite/pyodide-kernel/blob/395525f14b827968cb89a0e507123ae2932d399a/packages/pyodide-kernel/py/pyodide-kernel/pyodide_kernel/patches.py)