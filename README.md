# tomato

Projeto Flutter criado em uma pasta separada para consumir a API informada.

## Como rodar

Quando o Flutter estiver disponível no `PATH`:

```bash
flutter pub get
flutter run -d chrome
```

Para validar as chamadas reais da API e o HLS sem CORS do navegador, prefira:

```bash
flutter run -d android
```

Para gerar as plataformas nativas caso o SDK reclame que faltam pastas:

```bash
flutter create .
flutter pub get
```

O token de desenvolvimento foi colocado no cliente HTTP porque o projeto ainda é local.
