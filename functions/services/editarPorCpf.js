const { BigQuery } = require('@google-cloud/bigquery');
const bigquery = new BigQuery();

module.exports = async function editarPorCpf(cpf, { name, email }) {
  const query = `
    UPDATE \`quiosquefood3000.QuiosqueFood.customers\`
    SET name = @name, email = @email
    WHERE cpf = @cpf
  `;

  const options = {
    query,
    params: { name, email, cpf }
  };

  const [job] = await bigquery.createQueryJob(options);
  await job.getQueryResults();
};
