let wasmModule = null;
let image_width = 0;
let image_height = 0;
let random_seed = 0;
let worker_id = -1;

const [log, flush] = (() => {
  let buffer = [];
  function flush() {
    if (buffer.length > 0) {
      console.log(
        new TextDecoder("utf-16").decode(new Uint16Array(buffer).valueOf())
      );
      buffer = [];
    }
  }
  function log(ch) {
    if (ch == "\n".charCodeAt(0)) {
      flush();
    } else if (ch == "\r".charCodeAt(0)) {
      /* noop */
    } else {
      buffer.push(ch);
    }
  }
  return [log, flush];
})();

function incrProgress() {
  self.postMessage({ type: "INCR_PROGRESS" });
}

function setPixel(x, r, g, b, a) {
  self.postMessage({ type: "SET_PIXEL", x, r, g, b, a });
}

const importObject = {
  imagedata: {
    set_pixel: (x, r, g, b, a) => setPixel(x, r, g, b, a),
  },
  spectest: {
    print_char: log,
  },
  random: {
    seed: () => random_seed,
  },
  progress: {
    incr_progress: () => incrProgress(),
  },
};

self.addEventListener("message", (event) => {
  if (event.data.type === "INIT") {
    WebAssembly.instantiateStreaming(
      fetch("target/wasm-gc/release/build/lib/lib.wasm"),
      importObject
    ).then((instantiatedModule) => {
      wasmModule = instantiatedModule;
      wasmModule.instance.exports._start();
    });
    const { width, height, seed, id } = event.data;
    image_width = width;
    image_height = height;
    random_seed = seed;
    worker_id = id;
    console.log(`Worker ${worker_id} ready.`);
  } else if (event.data.type === "RENDER") {
    console.log(`Worker ${worker_id} start render.`);
    const renderImage = wasmModule.instance.exports["render_image"];
    renderImage(image_width, image_height);
  } else if (event.data.type === "PARTIAL_RENDER") {
    const { start, end } = event.data;
    console.log(`Worker ${worker_id} start partial render ${start}-${end}.`);
    const partialRenderImage =
      wasmModule.instance.exports["partial_render_image"];
    partialRenderImage(image_width, image_height, start, end);
  }
});
