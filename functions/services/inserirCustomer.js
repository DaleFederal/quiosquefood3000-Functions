const { BigQuery } = require('@google-cloud/bigquery');
const instancia = new BigQuery();

module.exports = async function inserirCustomer({ name, email, cpf }) {
  try {
    const insertQuery = `
      INSERT INTO \`quiosquefood3000.QuiosqueFood.customers\` (id, name, email, cpf)
      SELECT 
        COALESCE(MAX(id), 0) + 1 as novo_id,
        @name as name,
        @email as email,
        @cpf as cpf
      FROM \`quiosquefood3000.QuiosqueFood.customers\`
    `;

    const options = {
      query: insertQuery,
      params: { name, email, cpf },
    };

    const [rows] = await instancia.query(options);
    console.log('Inserção executada:', rows);

    const getIdQuery = `
      SELECT id FROM \`quiosquefood3000.QuiosqueFood.customers\`
      WHERE cpf = @cpf
      ORDER BY id DESC
      LIMIT 1
    `;

    const [idRows] = await instancia.query({
      query: getIdQuery,
      params: { cpf }
    });

    const novoId = parseInt(idRows[0]?.id);
    console.log('ID gerado:', novoId);

    return {
      id: novoId,
      message: 'Customer inserido com sucesso.'
    };

  } catch (error) {
    console.error('Erro ao inserir customer:', error);
    throw new Error(`Falha ao inserir customer: ${error.message}`);
  }
};