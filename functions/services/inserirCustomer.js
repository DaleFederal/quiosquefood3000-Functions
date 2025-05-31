const { BigQuery } = require('@google-cloud/bigquery');
const instancia = new BigQuery();

module.exports = async function inserirCustomer({ name, email, cpf }) {
  const consultaIdQuery = `
    SELECT IFNULL(MAX(id), 0) as maxId
    FROM \`quiosquefood3000.QuiosqueFood.customers\`
  `;

  const [job] = await instancia.createQueryJob({ query: consultaIdQuery });
  const [rows] = await job.getQueryResults();
  const maxId = rows[0]?.maxId || 0;
  const novoId = maxId + 1;

  const insertQuery = `
    INSERT INTO \`quiosquefood3000.QuiosqueFood.customers\` (id, name, email, cpf)
    VALUES (@id, @name, @email, @cpf)
  `;

  const options = {
    query: insertQuery,
    params: { id: novoId, name, email, cpf },
  };

  const [insertJob] = await instancia.createQueryJob(options);
  await insertJob.getQueryResults();

  return {
    id: novoId,
    message: 'Customer inserido com sucesso.',
  };
};
