const { BigQuery } = require('@google-cloud/bigquery');
const bigquery = new BigQuery();

module.exports = async function editarPorCpf(cpf, { nome, email }) {
  const query = `
    UPDATE \`quiosquefood3000.QuiosqueFood.customers\`
    SET nome = @nome, email = @email
    WHERE cpf = @cpf
  `;

  const options = {
    query,
    params: { nome, email, cpf }
  };

  const [job] = await bigquery.createQueryJob(options);
  await job.getQueryResults();
};
