const { BigQuery } = require('@google-cloud/bigquery');
const bigquery = new BigQuery();

module.exports = async function pesquisarPorCpf(cpf) {
  const query = `
    SELECT id, name, email, cpf
    FROM \`quiosquefood3000.QuiosqueFood.customers\`
    WHERE cpf = @cpf
  `;

  const options = {
    query,
    params: { cpf }
  };

  const [job] = await bigquery.createQueryJob(options);
  const [rows] = await job.getQueryResults();
  return rows;
};