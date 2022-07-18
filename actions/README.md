# Github Actions for Rperform

This folder contains the [Github Actions](https://github.com/features/actions) used when benchmarking a package with Rperform. There are two actions in the workflow :

* [EngineerDanny/Rperform/actions/receive](https://github.com/EngineerDanny/Rperform/tree/main/actions/receive)
  * Triggered via PR or push to main branch.
  * Reads `config.json` to prepare and run the benchmark job.
  * Does not have read or write access due to [security reasons](https://securitylab.github.com/research/github-actions-preventing-pwn-requests/).


* [EngineerDanny/Rperform/actions/comment](https://github.com/EngineerDanny/Rperform/tree/main/actions/comment)
  * Comments the results on the PR that originated the workflow run. 
  * Starts right after the `receive` job finishes.
  * Will create an additional commit status to the PR check suite. 
  * Has read & write access.
  
**NB** :  The version number of the action must be the same as the version number of the Rperform package.
e.g. `Rperform v0.0.1`:
```yaml
- uses EngineerDanny/Rperform/actions/receive@v0.0.1
```