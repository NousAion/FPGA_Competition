# Git 协作约定

`main` 只接受可综合、可复现的变更。功能开发使用 `feat/<name>`，修复使用 `fix/<name>`，文档使用 `docs/<name>`。

提交前至少检查：

```powershell
git status
git diff --check
git ls-files
```

禁止提交 `impl/`、`sim_work/`、`transcript`、用户状态文件和大体积生成物。新模块应同时提交 RTL、testbench、接口说明和必要约束变更。
