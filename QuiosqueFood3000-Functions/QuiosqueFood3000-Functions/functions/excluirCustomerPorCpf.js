const excluirPorCpf = require('../services/excluirPorCpf');

module.exports = async function excluirCustomerPorCpf (req, res) {
  try {
    const { cpf } = req.query;

    if (!cpf) {
      return res.status(400).json({ error: 'CPF é obrigatório.' });
    }

    await excluirPorCpf(cpf);

    res.status(200).json({ message: 'Customer excluído com sucesso.' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message });
  }
};
