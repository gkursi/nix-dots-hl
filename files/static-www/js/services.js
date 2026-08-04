const COLORS = ["purple", "aqua", "blue", "green", "yellow", "red", "gray"];
const VALID = new Set(COLORS);

const container = document.getElementById("services");

function card(service) {
  const color = VALID.has(service.color) ? service.color : "gray";
  const isPlaceholder = service.placeholder || !service.url;

  const col = document.createElement("div");
  col.className = "col";

  const el = document.createElement(isPlaceholder ? "div" : "a");
  el.className = "box box-" + color + " service";
  if (isPlaceholder) {
    el.classList.add("placeholder");
  } else {
    el.href = service.url;
    el.rel = "noopener";
  }

  const name = document.createElement("span");
  name.className = "service-name";
  name.textContent = service.name;
  el.appendChild(name);

  if (service.description) {
    const desc = document.createElement("span");
    desc.className = "service-desc small";
    desc.textContent = service.description;
    el.appendChild(desc);
  }

  col.appendChild(el);
  return col;
}

function render(services) {
  container.textContent = "";
  for (const service of services) {
    container.appendChild(card(service));
  }
}

async function main() {
  try {
    const res = await fetch("/services.json");
    if (!res.ok) throw new Error("HTTP " + res.status);
    const data = await res.json();
    if (!Array.isArray(data.services)) throw new Error("no services array");
    render(data.services);
  } catch (err) {
    render([
      {
        name: "oops :(",
        description: "couldn't load services.json (" + err + ")",
        color: "gray",
        // placeholder: true,
      },
      {
        name: "oops :(",
        description: "couldn't load services.json (" + err + ")",
        color: "gray",
        // placeholder: true,
      },
      {
        name: "oops :(",
        description: "couldn't load services.json (" + err + ")",
        color: "gray",
        // placeholder: true,
      },
    ]);
  }
}

main();
