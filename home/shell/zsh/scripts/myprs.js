#!/usr/bin/env bun

import { $ } from "bun";

import os from "node:os";
import chalk from "chalk";
import dropRight from "lodash/dropRight";
import last from "lodash/last";

console.log(chalk.blue("Listing my pull requests..."));

function shortTeam(team) {
  return team
    ?.toLowerCase()
    .split(/[-/]/)
    .filter((part) => part !== "frontend" && part !== "lumapps")
    .join("-");
}

const me = "gcornut";
const repos = process.env.MYREPOS.split(",").map((r) =>
  r.replace(/^~\//, `${os.homedir()}/`),
);
const fields =
  "number,url,isDraft,title,reviewRequests,reviewDecision,labels,assignees";
async function listPR(repo, fk, fv) {
  const res = $`gh pr list ${fk} ${fv} --json ${fields} --search "draft:false"`
    .cwd(repo)
    .quiet();
  return await res.json();
}

const hasLabel = (label, pr) => pr.labels?.find((l) => l.name === label);

console.log("Listing ", repos);
const prs = await Promise.all([
  ...repos.map((repo) => listPR(repo, "--author", me)),
  ...repos.map((repo) => listPR(repo, "--assignee", me)),
]).then((lists) => lists.flat());

const needReview = [];
const needTest = [];
const needMerge = [];
const others = [];

for (const pr of prs) {
  if (
    pr.reviewDecision === "REVIEW_REQUIRED" &&
    !hasLabel("need: dev-frontend", pr)
  )
    needReview.push(pr);
  else if (hasLabel("need: test", pr)) needTest.push(pr);
  else if (hasLabel("reviewed-and-tested", pr)) needMerge.push(pr);
  else others.push(pr);
}

function format(pr) {
  const requests = pr.reviewRequests
    .map(({ slug }) => shortTeam(slug))
    .filter(Boolean)
    .map((n) => chalk.bold(n));
  const formattedRequests = [dropRight(requests).join(", "), last(requests)]
    .filter(Boolean)
    .join(" et ");

  const assignedToMe =
    pr.assignees?.find((a) => a.login === me) && chalk.bold("[ASSIGNED]");

  const line = [assignedToMe, formattedRequests, pr.url, pr.title]
    .filter(Boolean)
    .join(" ");
  return `- ${line}`;
}

console.log(chalk.magenta("Need review:"));
for (const pr of needReview) {
  console.log(format(pr));
}

console.log(chalk.green("Need test:"));
for (const pr of needTest) {
  console.log(format(pr));
}

console.log(chalk.green("Need merge:"));
for (const pr of needMerge) {
  console.log(format(pr));
}
for (const pr of needMerge) {
  console.log(
    `:pr-request-merge ${pr.url.replace(/.*\/([^\/]+\/[^\/]+)\/pull\/(\d+).*/, "-R $1 $2")}`,
  );
}

console.log(chalk.green("Others:"));
for (const pr of others) {
  console.log(format(pr));
}
