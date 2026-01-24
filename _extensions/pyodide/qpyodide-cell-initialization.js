// Handle cell initialization initialization
qpyodideCellDetails.map(
    (entry) => {
      // Handle the creation of the element
      qpyodideCreateCell(entry);
    }
  );

// Auto-run cells that have autorun option set
(async function() {
  // Wait for Pyodide to be fully ready (poll until mainPyodide is available)
  const waitForPyodide = () => {
    return new Promise((resolve) => {
      const check = () => {
        if (typeof mainPyodide !== 'undefined' && mainPyodide) {
          resolve(mainPyodide);
        } else {
          setTimeout(check, 100);
        }
      };
      check();
    });
  };

  await waitForPyodide();

  // Run cells with autorun option
  for (const entry of qpyodideCellDetails) {
    if (entry.options?.autorun === 'true' || entry.options?.autorun === true) {
      try {
        await mainPyodide.loadPackagesFromImports(entry.code);
        const output = await mainPyodide.runPythonAsync(entry.code);

        // Display output in the cell's output area if it exists
        const outputDiv = document.getElementById(`qpyodide-output-code-area-${entry.id}`);
        if (outputDiv && output) {
          const pre = document.createElement("pre");
          const div = document.createElement("div");
          div.textContent = String(output);
          pre.appendChild(div);
          outputDiv.innerHTML = "";
          outputDiv.appendChild(pre);
        }
      } catch (err) {
        const outputDiv = document.getElementById(`qpyodide-output-code-area-${entry.id}`);
        if (outputDiv) {
          const pre = document.createElement("pre");
          pre.style.color = "red";
          pre.textContent = String(err);
          outputDiv.innerHTML = "";
          outputDiv.appendChild(pre);
        }
      }
    }
  }
})();
