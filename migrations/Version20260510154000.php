<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;

final class Version20260510154000 extends AbstractMigration
{
    public function getDescription(): string
    {
        return 'Create sujet_tagged_psychologue join table for front forum tagged psychologists.';
    }

    public function up(Schema $schema): void
    {
        $this->addSql('CREATE TABLE IF NOT EXISTS sujet_tagged_psychologue (id_sujet INT NOT NULL, id_psychologue INT NOT NULL, INDEX IDX_786D4DCEC09618AD (id_sujet), INDEX IDX_786D4DCECED9C570 (id_psychologue), PRIMARY KEY(id_sujet, id_psychologue)) DEFAULT CHARACTER SET utf8mb4 COLLATE `utf8mb4_unicode_ci` ENGINE = InnoDB');
        $this->addSql("SET @fk_exists = (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA = DATABASE() AND TABLE_NAME = 'sujet_tagged_psychologue' AND CONSTRAINT_NAME = 'FK_786D4DCEC09618AD')");
        $this->addSql("SET @sql = IF(@fk_exists = 0, 'ALTER TABLE sujet_tagged_psychologue ADD CONSTRAINT FK_786D4DCEC09618AD FOREIGN KEY (id_sujet) REFERENCES sujet_forum (id) ON DELETE CASCADE', 'SELECT 1')");
        $this->addSql('PREPARE stmt FROM @sql');
        $this->addSql('EXECUTE stmt');
        $this->addSql('DEALLOCATE PREPARE stmt');

        $this->addSql("SET @fk_exists = (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA = DATABASE() AND TABLE_NAME = 'sujet_tagged_psychologue' AND CONSTRAINT_NAME = 'FK_786D4DCECED9C570')");
        $this->addSql("SET @sql = IF(@fk_exists = 0, 'ALTER TABLE sujet_tagged_psychologue ADD CONSTRAINT FK_786D4DCECED9C570 FOREIGN KEY (id_psychologue) REFERENCES `user` (id) ON DELETE CASCADE', 'SELECT 1')");
        $this->addSql('PREPARE stmt FROM @sql');
        $this->addSql('EXECUTE stmt');
        $this->addSql('DEALLOCATE PREPARE stmt');
    }

    public function down(Schema $schema): void
    {
        $this->addSql('ALTER TABLE sujet_tagged_psychologue DROP FOREIGN KEY FK_786D4DCEC09618AD');
        $this->addSql('ALTER TABLE sujet_tagged_psychologue DROP FOREIGN KEY FK_786D4DCECED9C570');
        $this->addSql('DROP TABLE sujet_tagged_psychologue');
    }
}
