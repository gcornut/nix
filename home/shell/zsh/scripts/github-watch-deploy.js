#!/usr/bin/env bun

import { $ } from "bun";
import { timeout, getWhilePending } from "./utils";

async function getFromBody() {
  const res = await $`gh pr view --json 'body'`.json();

  for (const line of res.body.split(/[\r\n]+/).reverse()) {
    if (line.match(/^(Storybook )?(Partial )?Test:.*deploying/i))
      return "PENDING";
    if (line.match(/^(Storybook )?(Partial )?Test:.*/i)) return "DEPLOYED";
  }
  return "UNDEPLOYED";
}

async function getFromChecks() {
  const res = await $`gh pr checks --json name,state,workflow,link`.json();
  const pending = res.some(
    ({ workflow, state }) =>
      workflow.match(/deploy/i) &&
      (state === "QUEUED" || state === "IN_PROGRESS"),
  );
  return pending ? "PENDING" : "DONE";
}

const state = await timeout(
  // Timeout 30min
  1000 * 60 * 30,
  () => getWhilePending(getFromChecks).then(() => getWhilePending(getFromBody)),
);

process.assert(state === "DEPLOYED");
