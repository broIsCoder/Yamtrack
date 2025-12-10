# Deploying Yamtrack to Render

This guide outlines how to deploy Yamtrack to [Render](https://render.com) using its Docker runtime.

## Prerequisites
- A [Render](https://render.com) account.
- A fork of the [Yamtrack repository](https://github.com/FuzzyGrim/Yamtrack) on GitHub/GitLab.

## Step 1: Create a PostgreSQL Database
Yamtrack requires a persistent database.
1. Go to your Render Dashboard and create a **New PostgreSQL**.
2. Name it (e.g., `yamtrack-db`).
3. Select the region and plan (Free tier works availability permitting).
4. Once created, copy the **Internal Database URL** (wait for it to be available).

## Step 2: Create a Web Service
1. Go to the dashboard and create a **New Web Service**.
2. Connect your repository.
3. Choose the **Docker** runtime.
4. Region: Choose the same region as your database.
5. **Instance Type**: 'Starter' is recommended as the 'Free' tier may run out of memory during build or runtime, but you can try Free first.

## Step 3: Configure Environment Variables
Scroll down to "Environment Variables" and add the following keys. Refer to `env.example` or the wiki for more options.

| Key | Value | Description |
| --- | --- | --- |
| `SECRET` | `(generate a long random string)` | Security key for Django. |
| `DEBUG` | `False` | Disable debug mode for production. |
| `ALLOWED_HOSTS` | `*` | Or set to your Render URL (unnecessary if using URLS). |
| `URLS` | `https://your-app-name.onrender.com` | Your Render application URL. |
| `DB_HOST` | `(from database)` | The hostname from your Render Postgres. |
| `DB_NAME` | `(from database)` | Database name. |
| `DB_USER` | `(from database)` | Database username. |
| `DB_PASSWORD` | `(from database)` | Database password. |
| `DB_PORT` | `5432` | Standard PostgreSQL port. |
| `NO_REDIS` | `True` | **Simplest setup**: Run without Redis/Celery complications initially. |

> **Note on Redis**: If you want background tasks (notifications, faster caching), create a Render Redis instance and set `REDIS_URL` and `NO_REDIS=False`.

## Step 4: Persistent Storage (Important)
By default, Render Web Services are ephemeral. Files uploaded (like poster images) will be lost when the service restarts.
*   **Database**: Is safe because we used a managed PostgreSQL instance.
*   **Media Files**: To persist user uploads, you must add a **Disk**.
    1. In the Web Service settings, go to **Disks**.
    2. Add a disk. Mount path: `/yamtrack/src/media` (Check `settings.py` `MEDIA_ROOT` if uncertain, usually it's `media`).
    *   *Correction*: The Dockerfile workdir is `/yamtrack`. The code is in `/yamtrack`. Django media root defaults to `/yamtrack/media` or similar. Add a disk mounted at `/yamtrack/media`.

## Step 5: Deploy
Click **Create Web Service**. Render will build the Docker image and start the service.
The `entrypoint.sh` script automatically runs `python manage.py migrate`, so your database tables will be created on startup.

## Troubleshooting
*   **Build Failures**: Check the logs. If it's an OOM (Out Of Memory) error, you may need to upgrade to a Starter instance.
*   **Database connection**: Ensure you are using the *Internal* URL/Hostname if both services are in the same region, to save on latency and costs.
