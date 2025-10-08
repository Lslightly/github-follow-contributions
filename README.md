# github-follow-contributions

帮你收集 (~~视奸~~) 你 follow 的所有用户最近都贡献了哪些仓库。

Help you to see what repositories people you follow have recently contributed to.

## Setup

use [`uv sync`](https://docs.astral.sh/uv/getting-started/features/#projects) to get dependencies. Use `source .venv/bin/activate` to activate the environment.

GitHub personal access token is required:

- Apply it [here](https://github.com/settings/personal-access-tokens).
- The **read permission of followers** is needed. Permissions -> Followers -> Access: Read-only -> Generate token.

`OPENAI_API_KEY` is also required.

Once you get the personal access token and `OPENAI_API_KEY`, copy `.env.example` to `.env` and set variables accordingly.

```bash
python3 main.py
```

## Special Attention

If you want to give special attention to some users, use [cp_all.sh](cp_all.sh) to generate [special.yaml](special.yaml) from [all.yaml](all.yaml) and then comment out users.

If you want to see all users you are following, please remove [special.yaml](special.yaml).

## Development

Host the website:

```bash
npm run dev
```

## Local Preview

Run following commands to generate static website in `dist` directory.

```bash
npm run build
cp events.json dist
cd dist
```

Host the website:

```bash
python3 -m http.server # then open http://localhost:8000
```

You can filter events that you are interested in.

![preview](https://github.com/user-attachments/assets/5c0b04b0-144c-4987-9470-57c8f1f7345c)

## GitHub Pages

(In repository page)

1. Settings -> Secrets and variables -> Actions -> Repository secrets -> set secrets according to [.env.example](./.env.example).
2. Settings -> Actions -> General -> Workflow permissions -> **Read and write permissions**.
3. Actions -> Build and Deploy to GitHub Pages -> **Run workflow**.
4. Settings -> GitHub Pages -> Source: `gh-pages` branch.

## License

MIT
