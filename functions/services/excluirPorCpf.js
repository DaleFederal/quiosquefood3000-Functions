const { BigQuery } = require('@google-cloud/bigquery');
const bigquery = new BigQuery();

module.exports = async function excluirPorCpf(cpf) {
  const query = `
    DELETE FROM \`quiosquefood3000.QuiosqueFood.customers\`
    WHERE cpf = @cpf
  `;

  const options = {
    query,
    params: { cpf }
  };

  const [job] = await bigquery.createQueryJob(options);
  await job.getQueryResults();
};
