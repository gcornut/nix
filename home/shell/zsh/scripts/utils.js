export const sleep = (ms) => {
  let cancel;
  const promise = new Promise((resolve, reject) => {
    const timeoutId = setTimeout(resolve, ms);
    cancel = () => {
      clearTimeout(timeoutId);
      reject();
    };
  });
  promise.cancel = cancel;
  return promise;
};

export async function timeout(ms, get) {
  const promise = sleep(ms);
  const res = await Promise.race([
    promise.then(() => {
      new Error("Timeout " + ms);
    }),
    get(),
  ]);
  promise.cancel();
  return res;
}

export async function getWhilePending(get) {
  const state = await get();
  process.stdout.clearLine(0);
  process.stdout.cursorTo(0);
  process.stdout.write(state);
  if (state === "PENDING") {
    await sleep(800);
    process.stdout.write(".");
    await sleep(800);
    process.stdout.write(".");
    await sleep(800);
    process.stdout.write(".");
    return getWhilePending(get);
  }
  process.stdout.write("\n");
  return state;
}
