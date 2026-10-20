const fs = require('fs');
const path = require('path');

// Função principal que orquestra o processo
async function main() {
    try {
        // 1. Pega o caminho da imagem a partir dos argumentos da linha de comando
        const imagePath = process.argv[2];
        const nomeJsonDimensoes = process.argv[3] || 'dimensoes.json';

        if (!imagePath) {
            throw new Error('Por favor, forneça o caminho para a imagem como argumento. Ex: node imageSize.js C:\\caminho\\para\\imagem.jpg');
        }

        if (!fs.existsSync(imagePath)) {
            throw new Error(`O arquivo não foi encontrado em: ${imagePath}`);
        }

        // 2. Obtém as dimensões da imagem
        const dimensions = await getImageSize(imagePath);

        // 3. Prepara o conteúdo JSON
        const jsonOutput = JSON.stringify(dimensions, null, 2); // O 'null, 2' formata o JSON para ser legível

        // 4. Salva o arquivo JSON no mesmo diretório do script
        const outputFilePath = path.join(__dirname, nomeJsonDimensoes);
        fs.writeFileSync(outputFilePath, jsonOutput);

        console.log('Arquivo de dimensões gerado com sucesso!');
        console.log(`Largura: ${dimensions.width}px`);
        console.log(`Altura: ${dimensions.height}px`);
        console.log(`Salvo em: ${outputFilePath}`);

    } catch (error) {
        console.error('Ocorreu um erro:', error.message);
        process.exit(1); // Encerra o processo com código de erro
    }
}

/**
 * Lê o cabeçalho de um arquivo de imagem e retorna suas dimensões.
 * @param {string} filePath O caminho para o arquivo de imagem.
 * @returns {Promise<{width: number, height: number}>} Uma promessa que resolve com as dimensões.
 */
function getImageSize(filePath) {
    return new Promise((resolve, reject) => {
        // Lê apenas os primeiros bytes do arquivo para performance
        const readStream = fs.createReadStream(filePath, { start: 0, end: 65535 }); // Lê os primeiros 64KB
        const chunks = [];

        readStream.on('data', (chunk) => {
            chunks.push(chunk);
        });

        readStream.on('end', () => {
            const buffer = Buffer.concat(chunks);

            // Tenta identificar o formato e extrair as dimensões
            try {
                // PNG: Assinatura mágica: 89 50 4E 47 0D 0A 1A 0A
                if (buffer.toString('hex', 0, 8) === '89504e470d0a1a0a') {
                    // O chunk IHDR contém as dimensões
                    const width = buffer.readUInt32BE(16);
                    const height = buffer.readUInt32BE(20);
                    return resolve({ width, height });
                }

                // JPEG: Procura por marcadores SOF (Start of Frame)
                if (buffer[0] === 0xFF && buffer[1] === 0xD8) { // Marcador SOI (Start of Image)
                    let i = 2;
                    while (i < buffer.length) {
                        if (buffer[i] === 0xFF && (buffer[i+1] === 0xC0 || buffer[i+1] === 0xC2)) { // SOF0 ou SOF2
                            const height = buffer.readUInt16BE(i + 5);
                            const width = buffer.readUInt16BE(i + 7);
                            return resolve({ width, height });
                        }
                        // Pula para o próximo segmento
                        i += 2 + buffer.readUInt16BE(i + 2);
                    }
                }

                // GIF: Assinatura "GIF87a" ou "GIF89a"
                if (buffer.toString('ascii', 0, 6) === 'GIF87a' || buffer.toString('ascii', 0, 6) === 'GIF89a') {
                    const width = buffer.readUInt16LE(6);
                    const height = buffer.readUInt16LE(8);
                    return resolve({ width, height });
                }
                
                // BMP: Assinatura "BM"
                if (buffer.toString('ascii', 0, 2) === 'BM') {
                    const width = buffer.readInt32LE(18);
                    const height = buffer.readInt32LE(22);
                    return resolve({ width, height });
                }

                reject(new Error('Formato de imagem não suportado ou arquivo corrompido. Suportados: JPEG, PNG, GIF, BMP.'));

            } catch (e) {
                reject(new Error('Não foi possível analisar o arquivo de imagem. Pode estar corrompido.'));
            }
        });

        readStream.on('error', (err) => {
            reject(err);
        });
    });
}

// Inicia a execução do script
main();