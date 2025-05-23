const inserirCustomer = require('../services/inserirCustomer');

module.exports = async function customerPubSubMessenger(evento) {
  try {
    const customerCodificada = evento.data;
    const json = Buffer.from(customerCodificada, 'base64').toString();
    const customer = JSON.parse(json);

    const resultado = await inserirCustomer(customer);
    console.log('Customer inserido:', resultado);
  } catch (erro) {
    console.error('Erro ao processar mensagem PubSub:', erro);
    if (erro.response) {
      console.error('Detalhes:', JSON.stringify(erro.response));
    }
  }
};
