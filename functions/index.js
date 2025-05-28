const functions = require('@google-cloud/functions-framework');
const admin = require('firebase-admin');

admin.initializeApp();

const criarCustomers = require('./criarCustomers');
const editarCustomerPorCpf = require('./editarCustomerPorCpf');
const excluirCustomerPorCpf = require('./excluirCustomerPorCpf');
const pesquisarCustomerPorCpf = require('./pesquisarCustomerPorCpf');

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

functions.http('criarCustomer', async (req, res) => {
  await autenticar(req, res);
  await criarCustomers(req, res);
});

functions.http('editarCustomerPorCpf', async (req, res) => {
  await autenticar(req, res);
  await editarCustomerPorCpf(req, res);
});

functions.http('excluirCustomerPorCpf', async (req, res) => {
  await autenticar(req, res);
  await excluirCustomerPorCpf(req, res);
});

functions.http('pesquisarCustomerPorCpf', async (req, res) => {
  await autenticar(req, res);
  await pesquisarCustomerPorCpf(req, res);
});
