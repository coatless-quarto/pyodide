# Pyodide Extension for Quarto HTML Documents

**We're working on finalizing the Quarto extension. We expect this to be completed shortly.**

This extension enables the [Pyodide](https://pyodide.org/en/stable/) code cell within various [Quarto](https://quarto.org/) formats, including [HTML](https://quarto.org/docs/output-formats/html-basics.html), [RevealJS](https://quarto.org/docs/presentations/revealjs/), [Websites](https://quarto.org/docs/websites/), [Blogs](https://quarto.org/docs/websites/website-blog.html), and [Books](https://quarto.org/docs/books). 

## Installation 

To use this extension in a [Quarto project](https://quarto.org/docs/projects/quarto-projects.html), install it from within the project's working directory by typing into **Terminal**:

``` bash
quarto add coatless-quarto/pyodide
```

After the installation process is finished, the extension will be readily available for Quarto documents within the designated working directory. Please note that if you are working on projects located in different directories, you will need to repeat this installation step for each of those directories.

## Usage

For each document, place the `pyodide` filter in the document's header:

```yaml
filters:
  - pyodide
```

Then, place the Python code for `Pyodide` in a code block marked with `{pyodide-python}`

````markdown
---
title: Pyodide in Quarto HTML Documents
format: html
filters:
  - pyodide
---

This is a pyodide-enabled code cell in a Quarto HTML document.

```{pyodide-python}
n = 5
while n > 0:
  print(n)
  n = n - 1

print('Blastoff!')
```
````

The rendered document can be viewed online [here](https://quarto.thecoatlessprofessor.com/pyodide/examples/readme).

## Help

To report a bug, please [add an issue](https://github.com/coatless-quarto/pyodide/issues/new) to the repository's [bug tracker](https://github.com/coatless-quarto/pyodide/issues).

Want to contribute a feature? Please open an issue ticket to discuss the feature before sending a pull request. 

## Acknowledgements

Please see our [acknowledgements page](https://quarto.thecoatlessprofessor.com/pyodide/qpyodide-acknowledgements.html).