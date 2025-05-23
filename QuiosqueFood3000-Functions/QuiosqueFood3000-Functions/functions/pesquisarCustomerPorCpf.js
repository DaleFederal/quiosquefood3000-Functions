const pesquisarPorCpf = require('../services/pesquisarPorCpf');

module.exports = async function pesquisarCustomerPorCpf (req, res) {
  try {
    const { cpf } = req.query;

    if (!cpf) {
      return res.status(400).json({ error: 'CPF é obrigatório.' });
    }

    const resultados = await pesquisarPorCpf(cpf);

    if (resultados.length === 0) {
      return res.status(404).json({ message: 'Customer não encontrado.' });
    }

    res.status(200).json(resultados);
  } catch (erro) {
    console.error(erro);
    res.status(500).json({ error: erro.message });
  }
};