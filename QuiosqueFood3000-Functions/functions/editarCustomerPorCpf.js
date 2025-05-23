const editarPorCpf = require('../services/editarPorCpf');

module.exports = async function editarCustomerPorCpf (req, res)  {
  try {
    const { cpf } = req.query;
    const { nome, email } = req.body;

    if (!cpf) {
      return res.status(400).json({ error: 'CPF é obrigatório.' });
    }

    await editarPorCpf(cpf, { nome, email });

    res.status(200).json({ message: 'Customer atualizado com sucesso.' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message });
  }
};
