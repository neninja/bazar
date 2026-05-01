# Contribuindo

## DX

Experiência de desenvolvimento (DX)

### Configuração inicial

```shell
mix setup
```

### Execução servidor

```shell
mix phx.server
```

### Debug

- Utilize `dbg`
- Utilize a extensão `live_debugger`
- Utilize a rota `/dev/dashboard`

### Integração

Sempre que possível, rode os testes e formatação de código

```shell
mix precommit
```

## Testes end to end

Com ambiente `dev` (padrão), execute as instruções de `make e2e` e no projeto de e2e execute os testes