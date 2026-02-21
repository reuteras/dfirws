document.addEventListener("DOMContentLoaded", function () {
  // Find tables that have the tool table header structure
  const tables = document.querySelectorAll("table");
  tables.forEach(function (table) {
    const headers = table.querySelectorAll("thead th");
    if (headers.length < 5) return;

    const headerTexts = Array.prototype.map.call(headers, function (th) {
      return th.textContent.trim().toLowerCase();
    });

    const colTool = headerTexts.indexOf("tool");
    const colSource = headerTexts.indexOf("source");
    const colDesc = headerTexts.indexOf("description");
    const colTags = headerTexts.indexOf("tags");
    const colExt = headerTexts.indexOf("file extensions");

    // Only add filtering to tables that match the tool table structure
    if (colTool === -1 || colDesc === -1 || colTags === -1 || colExt === -1) return;

    const rows = table.querySelectorAll("tbody tr");
    if (rows.length === 0) return;

    // Collect unique tags and extensions for datalist suggestions
    const allTags = {};
    const allExts = {};
    rows.forEach(function (row) {
      const cells = row.querySelectorAll("td");
      if (cells.length <= Math.max(colTags, colExt)) return;

      const tagsText = cells[colTags].textContent.trim();
      tagsText.split(",").forEach(function (t) {
        t = t.trim();
        if (t) allTags[t] = true;
      });

      const extText = cells[colExt].textContent.trim();
      extText.split(",").forEach(function (e) {
        e = e.trim();
        if (e) allExts[e] = true;
      });
    });

    // Build filter container
    const container = document.createElement("div");
    container.className = "tool-filter";

    const tagId = "filter-tags-" + Math.random().toString(36).substr(2, 6);
    const extId = "filter-ext-" + Math.random().toString(36).substr(2, 6);

    container.innerHTML =
      '<div class="tool-filter-row">' +
        '<div class="tool-filter-field">' +
          '<label for="filter-desc">Filter by description</label>' +
          '<input type="text" id="filter-desc" placeholder="e.g. timeline" />' +
        "</div>" +
        '<div class="tool-filter-field">' +
          '<label for="' + tagId + '">Filter by tag</label>' +
          '<input type="text" id="' + tagId + '" list="' + tagId + '-list" placeholder="e.g. malware-analysis" />' +
          '<datalist id="' + tagId + '-list">' +
            Object.keys(allTags).sort().map(function (t) { return '<option value="' + t + '">'; }).join("") +
          "</datalist>" +
        "</div>" +
        '<div class="tool-filter-field">' +
          '<label for="' + extId + '">Filter by extension</label>' +
          '<input type="text" id="' + extId + '" list="' + extId + '-list" placeholder="e.g. .evtx" />' +
          '<datalist id="' + extId + '-list">' +
            Object.keys(allExts).sort().map(function (e) { return '<option value="' + e + '">'; }).join("") +
          "</datalist>" +
        "</div>" +
        '<div class="tool-filter-field tool-filter-actions">' +
          '<button type="button" class="tool-filter-clear">Clear</button>' +
          '<span class="tool-filter-count"></span>' +
        "</div>" +
      "</div>";

    table.parentNode.insertBefore(container, table);

    const inputTag = container.querySelector("#" + tagId);
    const inputExt = container.querySelector("#" + extId);
    const inputDesc = container.querySelector("#filter-desc");
    const clearBtn = container.querySelector(".tool-filter-clear");
    const countSpan = container.querySelector(".tool-filter-count");

    function applyFilter() {
      const filterTag = inputTag.value.trim().toLowerCase();
      const filterExt = inputExt.value.trim().toLowerCase();
      const filterDesc = inputDesc.value.trim().toLowerCase();

      let visible = 0;
      rows.forEach(function (row) {
        const cells = row.querySelectorAll("td");
        if (cells.length <= Math.max(colTags, colExt, colDesc)) return;

        const tagsText = cells[colTags].textContent.trim().toLowerCase();
        const extText = cells[colExt].textContent.trim().toLowerCase();
        const descText = cells[colDesc].textContent.trim().toLowerCase();

        const matchTag = !filterTag || tagsText.indexOf(filterTag) !== -1;
        const matchExt = !filterExt || extText.indexOf(filterExt) !== -1;
        const matchDesc = !filterDesc || descText.indexOf(filterDesc) !== -1;

        if (matchTag && matchExt && matchDesc) {
          row.style.display = "";
          visible++;
        } else {
          row.style.display = "none";
        }
      });

      const hasFilter = filterTag || filterExt || filterDesc;
      countSpan.textContent = hasFilter ? visible + " of " + rows.length + " tools" : rows.length + " tools";
    }

    inputTag.addEventListener("input", applyFilter);
    inputExt.addEventListener("input", applyFilter);
    inputDesc.addEventListener("input", applyFilter);

    clearBtn.addEventListener("click", function () {
      inputTag.value = "";
      inputExt.value = "";
      inputDesc.value = "";
      applyFilter();
    });

    // Show initial count
    applyFilter();
  });
});
