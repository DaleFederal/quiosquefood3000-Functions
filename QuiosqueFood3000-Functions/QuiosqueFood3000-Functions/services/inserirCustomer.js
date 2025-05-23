const { BigQuery } = require('@google-cloud/bigquery');
const instancia = new BigQuery();
const { randomUUID } = require('crypto');

module.exports = async function inserirCustomer({ nome, email, cpf }) {
  const id = randomUUID(); // Gera um ID único

  const query = `
    INSERT INTO \`quiosquefood3000.QuiosqueFood.customers\` (id, nome, email, cpf)
    VALUES (@id, @nome, @email, @cpf)
  `;

  const options = {
    query,
    params: { id, nome, email, cpf }
  };

  const [job] = await instancia.createQueryJob(options);
  await job.getQueryResults();

  return { id, message: 'Customer inserido com sucesso.' };
};
