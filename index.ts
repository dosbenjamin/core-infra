import { Cron } from 'croner';

type Backup = {
  database: {
    name: string,
    username: string,
    password: string,
    host: string,
    port: number,
  },
  options: {
    prefix: string,
  },
}

new Cron(Bun.env.BACKUP_SCHEDULER_CRON_PATTERN ?? '@daily', async () => {
  const backups: Backup[] = await Bun.file(`config/backups.json`).json();
  const date = new Date().toISOString();

  for (const { database, options } of backups) {
    try {
      const { stdout } = await Bun.$`pg_dump -O -d postgres://${database.username}:${database.password}@${database.host}:${database.port}/${database.name} | gzip`;
      const file = Bun.s3.file(`${options.prefix}/${date}.sql.gz`);
      await Bun.write(file, stdout);
      console.info(`Successfully backup '${options.prefix}'`);
    } catch(error) {
      console.error(`Backup of '${options.prefix}' failed`);
      console.error(error);
    }
  }
});
