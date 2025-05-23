
const PubSub = require('@google-cloud/pubsub').PubSub
const instancia = new PubSub({
    projectId: 'quiosquefood3000'
})

module.exports = function pubsub (dados, topico) {
    if (typeof dados !== 'string') {
        dados = JSON.stringify(dados)
    }

    dados = Buffer.from(dados)
    return instancia.topic(topico).publishMessage({data: dados})
}