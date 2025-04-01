// 定义协议常量
const HEADER = '8A8A';
const FOOTER = '8B8B';

// 实用函数：将Buffer或字节数组转为十六进制字符串
function toHexString(data) {
    if (typeof data === 'object' && data.constructor && data.constructor.name === 'Buffer') {
        // 将Buffer转换为十六进制字符串
        return Array.from(data).map(byte => byte.toString(16).padStart(2, '0')).join('').toUpperCase();
    } else if (Array.isArray(data)) {
        // 将字节数组转换为十六进制字符串
        return data.map(byte => byte.toString(16).padStart(2, '0')).join('').toUpperCase();
    } else if (typeof data === 'string') {
        // 移除空格并转为大写
        return data.replace(/\s/g, '').toUpperCase();
    }
    return '';
}

// 从指令号中提取命令ID
function extractCommandId(cmd) {
    if (cmd.length >= 4) {
        // 提取指令号的后两位作为命令ID
        const cmdId = cmd.substring(2, 4);
        return {
            cmdIdHex: cmdId,  // 十六进制字符串
            cmdIdNum: parseInt(cmdId, 16), // 数字
            cmdIdByte: parseInt(cmdId, 16) // 字节值
        };
    }
    return null;
}

// 流式协议解析器 - 使用状态机处理可能分多次接收的数据
class ProtocolParser {
    constructor() {
        this.buffer = '';
        this.packets = [];
    }

    // 添加新数据到缓冲区并尝试解析
    feed(data) {
        // 添加新数据到缓冲区
        this.buffer += toHexString(data);

        // 尝试解析完整的数据包
        this._parseBuffer();

        // 返回已解析的数据包
        const result = [...this.packets];
        this.packets = [];
        return result;
    }

    // 内部方法：从缓冲区中解析完整的数据包
    _parseBuffer() {
        while (true) {
            // 查找标头
            const headerIndex = this.buffer.indexOf(HEADER);
            if (headerIndex === -1) {
                // 没有标头，清空缓冲区
                this.buffer = '';
                break;
            }

            // 如果标头前有数据，删除它
            if (headerIndex > 0) {
                this.buffer = this.buffer.substring(headerIndex);
            }

            // 查找标尾
            const footerIndex = this.buffer.indexOf(FOOTER, HEADER.length);
            if (footerIndex === -1) {
                // 标尾不存在，等待更多数据
                break;
            }

            // 找出是否有嵌套的标头
            const nestedHeaderIndex = this.buffer.indexOf(HEADER, HEADER.length);

            // 如果嵌套的标头在当前标尾之前，需要检查它是否是有效的标头
            if (nestedHeaderIndex !== -1 && nestedHeaderIndex < footerIndex) {
                // 检查这个嵌套的标头是否有对应的标尾
                const nestedFooterIndex = this.buffer.indexOf(FOOTER, nestedHeaderIndex + HEADER.length);

                // 如果嵌套标头有对应的标尾，且它在当前标尾之前，我们应该处理这个嵌套的包
                if (nestedFooterIndex !== -1 && nestedFooterIndex < footerIndex) {
                    // 从缓冲区删除嵌套标头之前的无效数据
                    this.buffer = this.buffer.substring(nestedHeaderIndex);
                    continue; // 重新从嵌套标头开始解析
                }
            }

            // 提取完整的数据包
            const packet = this.buffer.substring(0, footerIndex + FOOTER.length);

            // 提取命令和数据
            const cmd = packet.substring(HEADER.length, HEADER.length + 4);
            const data = packet.substring(HEADER.length + 4, packet.length - FOOTER.length);

            // 提取命令ID
            const cmdId = extractCommandId(cmd);

            // 添加到解析结果
            this.packets.push({
                packet: packet,
                cmd: cmd,
                cmdId: cmdId,
                data: data
            });

            // 从缓冲区删除已处理的数据包
            this.buffer = this.buffer.substring(footerIndex + FOOTER.length);
        }
    }

    // 获取缓冲区状态
    getBufferState() {
        return this.buffer;
    }
}
const parser = new ProtocolParser();

export function streamProtocol(data) {
    return parser.feed(data);
}

/**
 * 将十六进制格式的数据转换为整数数组并按2字节分割
 * @param {string} data - 要转换的十六进制数据
 * @returns {number[]} - 转换后的整数数组
 */
export function dataToHexChunks(data) {
    // 确保输入是十六进制字符串
    if (typeof data !== 'string') {
        return [];
    }

    // 移除可能存在的空格
    data = data.replace(/\s/g, '');

    // 按2字节（4个十六进制字符）分割并转换为整数
    const chunks = [];
    for (let i = 0; i < data.length; i += 4) {
        const chunk = data.substring(i, i + 4);
        if (chunk.length > 0) {
            // 将十六进制字符串转换为整数
            chunks.push(parseInt(chunk.padEnd(4, '0'), 16));
        }
    }

    return chunks;
}
