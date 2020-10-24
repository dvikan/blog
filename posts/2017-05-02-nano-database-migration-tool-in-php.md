{"title": "Nano database migration tool in PHP"}

A migration tool applies changes to your database. I like to keep things simple:


    #!/usr/bin/env php
    <?php
    
    require __DIR__.'/../vendor/autoload.php';
    
    $dotenv = new Dotenv\Dotenv(__DIR__.'/../');
    $dotenv->load();
    $dotenv->required([
        'DSN',
        'DATABASE_USERNAME',
        'DATABASE_PASSWORD',
        'MIGRATIONS_FOLDER',
    ]);
    
    $pdo = new PDO(
        getenv('DSN'),
        getenv('DATABASE_USERNAME'),
        getenv('DATABASE_PASSWORD')
    );
    
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
    
    $pdo->query('create table if not exists migration (name varchar(255))');
    
    $folder = getenv('MIGRATIONS_FOLDER');
    
    foreach (new DirectoryIterator($folder) as $file) {
        if ($file->getFilename() === '.' || $file->getFilename() === '..')
            continue;
    
        $migrations[] = $file->getFilename();
    }
    
    sort($migrations);
    
    array_map(function ($migration) use ($pdo, $folder) {
    
        $stmt = $pdo->prepare('select * from migration where name=:name');
        $stmt->execute(['name' => $migration]);
    
        if (empty($stmt->fetchAll())) {
    
            print "Migrating $migration \n";
    
            $pdo->query(file_get_contents($folder . $migration));
    
            $pdo->prepare('insert into migration values (:name)')
                ->execute(['name' => $migration]);
        }
    }, $migrations);

The tool runs new migrations once. The migrations are `.sql` files e.g. 
`2017-05-01-create-initial-tables.sql`:

    create table contact(
        id int NOT NULL AUTO_INCREMENT,
        name varchar(255) NOT NULL,
        email varchar(255) NOT NULL unique,
        PRIMARY KEY (id)
    );

The tool has one dependency: `composer require vlucas/phpdotenv`.
