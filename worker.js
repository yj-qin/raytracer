let wasmModule = null;
let context = null;
let imagedata = null;
let image_width = 0;
let image_height = 0;

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

function setPixel(x, r, g, b, a) {
  imagedata.data[x] = r;
  imagedata.data[x + 1] = g;
  imagedata.data[x + 2] = b;
  imagedata.data[x + 3] = a;
}

function clearImage() {
  for (let i = 0; i < imagedata.data.length; i += 4) {
    imagedata.data[i] = 0;
    imagedata.data[i + 1] = 0;
    imagedata.data[i + 2] = 0;
    imagedata.data[i + 3] = 0;
  }
}

function showImage() {
  context.putImageData(imagedata, 0, 0);
}

function setProgress(progress) {
  self.postMessage({ type: "SET_PROGRESS", progress });
}

const importObject = {
  imagedata: {
    set_pixel: (x, r, g, b, a) => setPixel(x, r, g, b, a),
  },
  spectest: {
    print_char: log,
  },
  time: {
    timestamp: () => new Date().getTime(),
  },
  progress: {
    set_progress: (progress) => setProgress(progress),
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
    const { canvas, width, height } = event.data;
    image_width = width;
    image_height = height;
    context = canvas.getContext("2d");
    imagedata = context.createImageData(width, height);
  } else if (event.data.type === "RENDER") {
    clearImage();
    const renderImage = wasmModule.instance.exports["render_image"];
    renderImage(image_width, image_height);
    showImage();
    self.postMessage({ type: "DONE" });
  }
});
