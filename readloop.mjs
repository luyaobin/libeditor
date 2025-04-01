import fs from 'fs';

// 读取CSV文件
fs.readFile('loop.csv', 'utf8', (err, data) => {
    if (err) {
        console.error('读取文件时出错:', err);
        return;
    }

    // 按行分割数据
    const lines = data.split('\n');

    // 解析CSV数据
    const headers = lines[0].split(',');
    const rows = [];

    for (let i = 1; i < lines.length; i++) {
        if (lines[i].trim() === '') continue; // 跳过空行

        const values = lines[i].split(',');


        rows.push(values[3]);
        rows.push(values[6]);
    }

    console.log(`成功读取了${rows.length}行数据`);
    console.log('表头:', headers);
    console.log('前5行数据示例:');
    console.log(rows.slice(0, 5));
    console.log(new Set(rows))
    // 创建一个Set来存储唯一的模块名称
    const uniqueModules = new Set(rows);

    // 将Set转换为数组并排序
    const sortedModules = Array.from(uniqueModules).filter(Boolean).sort();

    // 将结果写入文件
    fs.writeFile('modules.txt', sortedModules.join('\n'), 'utf8', (err) => {
        if (err) {
            console.error('写入文件时出错:', err);
            return;
        }
        console.log(`成功将${sortedModules.length}个唯一模块名称写入到modules.txt文件中`);
    });
});
