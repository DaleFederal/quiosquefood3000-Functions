const pubsub = require('./pubsub');
const { BigQuery } = require('@google-cloud/bigquery');
const bigquery = new BigQuery();

async function cpfExiste(cpf) {
  const query = `
    SELECT cpf FROM \`quiosquefood3000.QuiosqueFood.customers\`
    WHERE cpf = @cpf
    LIMIT 1
  `;
  const options = { query, params: { cpf } };
  const [job] = await bigquery.createQueryJob(options);
  const [rows] = await job.getQueryResults();

  return rows.length > 0;
}

module.exports = async function criarCustomer(req, res) {
  const { nome, email, cpf } = req.body;

  if (!nome) return res.status(400).send('O campo nome não foi informado.');
  if (!email) return res.status(400).send('O campo email não foi informado.');
  if (!cpf) return res.status(400).send('O campo cpf não foi informado.');  

  if (await cpfExiste(cpf)) {
    return res.status(409).send('CPF já cadastrado.');
  }

  const resultado = await pubsub({ nome, email, cpf }, 'customers');
  console.log({ nome, email, cpf });

  res.status(201).send(resultado);
};
