#!/usr/bin/env bun

import { $ } from "bun";
import { getWhilePending } from "./utils";

async function isMerged() {
  const { state } = await $`gh pr view --json 'state'`.json();
  return state === "MERGED" ? "MERGED" : "PENDING";
}

await getWhilePending(isMerged);
