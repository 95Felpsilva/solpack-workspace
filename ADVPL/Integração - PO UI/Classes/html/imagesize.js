var websocketConnected = false
var tamanhoImagem = {
    status: true,
    widthPx: 0,
    heightPx: 0,
    message: ''
}

window.onload = function () {
    twebchannel.connect(() => {
        console.log('Websocket Connected!');
        websocketConnected = true
    });
};

async function imagesize(url = "./imagesize.jpg") {
    const resultadoEl = document.getElementById('resultado');

    if (!url) {
        resultadoEl.textContent = 'Por favor, insira uma URL.';
        return;
    }

    resultadoEl.textContent = 'Carregando...';

    try {
        // Chama a função principal e aguarda o resultado
        const dimensoes = await obterDimensoesDaImagem(url);
        resultadoEl.textContent = `Dimensões: ${dimensoes.widthPx}px (largura) x ${dimensoes.heightPx}px (altura)`;
        if (websocketConnected){
            twebchannel.jsToAdvpl("imagesize", JSON.stringify(dimensoes));
        }
    } catch (error) {
        // Captura e exibe qualquer erro que tenha ocorrido
        resultadoEl.textContent = `Erro: ${error}`;
    }
}

/**
* Recebe a URL de uma imagem e retorna suas dimensões (largura e altura) em pixels.
* A imagem é carregada em memória, sem ser exibida na tela.
* @param {string} url - A URL completa da imagem.
* @returns {Promise<{heightPx: number, widthPx: number, status:boolean, message: string}>} Uma Promise que resolve com um objeto contendo a largura e altura.
*/
function obterDimensoesDaImagem(url) {
    // Retorna uma Promise, pois o carregamento da imagem é uma operação assíncrona.
    return new Promise((resolve, reject) => {
        // Cria um novo objeto de Imagem em memória. Ele não faz parte do DOM.
        const img = new Image();

        // Função a ser executada quando a imagem carregar com sucesso.
        img.onload = function () {
            // Resolve a Promise, retornando um objeto com as dimensões.
            // 'naturalWidth' e 'naturalHeight' dão o tamanho original da imagem.
            tamanhoImagem.heightPx = this.naturalHeight
            tamanhoImagem.widthPx = this.naturalWidth
            tamanhoImagem.status = true
            resolve(tamanhoImagem);
        };

        // Função a ser executada se houver um erro ao carregar a imagem.
        img.onerror = function (error) {
            tamanhoImagem.status = false
            tamanhoImagem.message = error.message
            // Rejeita a Promise com uma mensagem de erro.
            reject(tamanhoImagem);
        };

        // Define o 'src' da imagem. Isso inicia o processo de carregamento.
        img.src = url;
    });
}