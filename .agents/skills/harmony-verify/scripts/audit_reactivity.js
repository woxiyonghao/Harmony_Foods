#!/usr/bin/env node
const fs = require('fs');
const path = require('path');

const PROJECT_ROOT = path.resolve(__dirname, '../../../..');
const ETS_DIR = path.join(PROJECT_ROOT, 'entry/src/main/ets');

let hasErrors = false;
const errors = [];
const warnings = [];

function getAllFiles(dir, exts = ['.ets', '.ts']) {
  let files = [];
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      files = files.concat(getAllFiles(fullPath, exts));
    } else if (exts.includes(path.extname(entry.name))) {
      files.push(fullPath);
    }
  }
  return files;
}

console.log('🔍 [1/3] 正在对 ArkTS/ArkUI 代码进行响应式循环与逻辑陷阱静态审查...');

const allFiles = getAllFiles(ETS_DIR);

for (const filePath of allFiles) {
  const content = fs.readFileSync(filePath, 'utf-8');
  const relPath = path.relative(PROJECT_ROOT, filePath);
  const lines = content.split('\n');

  // 1. 检查 Getter 函数中是否存在 AppStorage.setOrCreate（副作用引发无限循环）
  if (relPath.includes('FoodDBHelper.ets')) {
    let inGetter = false;
    let getterName = '';
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];
      if (/static\s+async\s+get\w+\(/.test(line) || /static\s+get\w+\(/.test(line)) {
        inGetter = true;
        getterName = line.trim();
      }
      if (inGetter && line.includes('AppStorage.setOrCreate')) {
        errors.push(`❌ [死循环隐患] ${relPath}:${i + 1} 在只读查询函数 (${getterName}) 中调用了 AppStorage.setOrCreate！这会导致订阅组件重复触发，引发 CPU 跑满和应用闪退！`);
        hasErrors = true;
      }
      if (inGetter && line.startsWith('  }')) {
        inGetter = false;
      }
    }
  }

  // 2. 检查 @StorageLink 是否在 @Watch 处理函数或其调用的加载方法中被直接赋值（自触发死循环）
  const storageLinkMatches = [...content.matchAll(/@StorageLink\(['"]([^'"]+)['"]\)(?:\s+@Watch\(['"]([^'"]+)['"]\))?\s+(\w+)\s*:/g)];
  for (const match of storageLinkMatches) {
    const key = match[1];
    const watchFunc = match[2];
    const varName = match[3];

    if (watchFunc) {
      const funcRegex = new RegExp(`(?:async\\s+)?${watchFunc}\\s*\\([^)]*\\)\\s*\\{([\\s\\S]*?)\\n  \\}`, 'g');
      const funcMatch = funcRegex.exec(content);
      if (funcMatch && funcMatch[1].includes(`this.${varName} =`)) {
        errors.push(`❌ [死循环隐患] ${relPath} 中 @StorageLink('${key}') 变量 '${varName}' 在其 @Watch 回调 '${watchFunc}' 中被重新赋值！这将导致无限自触发更新循环！建议改用 @State 存储本地展示副本。`);
        hasErrors = true;
      }
    }
  }

  // 3. 检查同一个组件中是否存在重复多余的 @Watch 绑定
  const watchCallRegex = /@Watch\(['"]([^'"]+)['"]\)/g;
  const watchCounts = {};
  let wMatch;
  while ((wMatch = watchCallRegex.exec(content)) !== null) {
    const fn = wMatch[1];
    watchCounts[fn] = (watchCounts[fn] || 0) + 1;
  }
  for (const [fn, count] of Object.entries(watchCounts)) {
    if (count > 2) {
      warnings.push(`⚠️ [性能警告] ${relPath} 中方法 '${fn}' 被绑定了 ${count} 次 @Watch，可能导致重复多次触发。建议合并为一个版本变更监听器。`);
    }
  }
}

console.log('----------------------------------------------------');
if (warnings.length > 0) {
  console.log(`⚠️ 发现 ${warnings.length} 处优化建议：`);
  warnings.forEach(w => console.log(w));
}

if (hasErrors) {
  console.error(`\n❌ 静态审查未通过！发现 ${errors.length} 处严重问题：`);
  errors.forEach(e => console.error(e));
  process.exit(1);
} else {
  console.log('✅ 静态审查通过：未发现 Getter 副作用或 @StorageLink 自循环死锁风险。');
}
