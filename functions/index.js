const admin = require('firebase-admin');
admin.initializeApp();

const criarCustomers = require('./functions/criarCustomers');
const editarCustomerPorCpf = require('./functions/editarCustomerPorCpf');
const excluirCustomerPorCpf = require('./functions/excluirCustomerPorCpf');
const pesquisarCustomerPorCpf = require('./functions/pesquisarCustomerPorCpf');
const customerPubSubMessenger = require('./functions/customerPubSubMessenger');

async function autenticar(req, res) {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    res.status(401).send({ error: 'Token não informado.' });
    throw new Error('Token não informado.');
  }

  const idToken = authHeader.split(' ')[1];

  try {
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    console.log('Usuário autenticado:', decodedToken);
    return decodedToken;
  } catch (error) {
    console.error('Erro na autenticação:', error);
    res.status(403).send({ error: 'Token inválido.' });
    throw new Error('Token inválido.');
  }
}

function proteger(fn) {
  return async (req, res) => {
    await autenticar(req, res);
    return fn(req, res);
  };
}

module.exports.criarCustomer = proteger(criarCustomers);
module.exports.editarCustomerPorCpf = proteger(editarCustomerPorCpf);
module.exports.excluirCustomerPorCpf = proteger(excluirCustomerPorCpf);
module.exports.pesquisarCustomerPorCpf = proteger(pesquisarCustomerPorCpf);
module.exports.customerPubSubMessenger = customerPubSubMessenger;
