const { OAuth2Client } = require('google-auth-library');
const client = new OAuth2Client();

const criarCustomerFn = require('./functions/criarCustomers');
const customerPubSubMessengerFn = require('./functions/customerPubSubMessenger');
const pesquisarCustomerPorCpfFn = require('./functions/pesquisarCustomerPorCpf');
const editarCustomerPorCpfFn = require('./functions/editarCustomerPorCpf');
const excluirCustomerPorCpfFn = require('./functions/excluirCustomerPorCpf');

async function autenticar(req, res) {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    res.status(401).send({ error: 'Token não informado.' });
    throw new Error('Token não informado.');
  }

  const idToken = authHeader.split(' ')[1];

  try {
    const ticket = await client.verifyIdToken({
      idToken,
      audience: process.env.PROJECT_ID,
    });

    const payload = ticket.getPayload();
    return payload;
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

exports.criarCustomer = proteger(criarCustomerFn);
exports.pesquisarCustomerPorCpf = proteger(pesquisarCustomerPorCpfFn);
exports.editarCustomerPorCpf = proteger(editarCustomerPorCpfFn);
exports.excluirCustomerPorCpf = proteger(excluirCustomerPorCpfFn);
exports.customerPubSubMessenger = customerPubSubMessengerFn;
