<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;

/**
 * Auto-generated Migration: Please modify to your needs!
 */
final class Version20260305000126 extends AbstractMigration
{
    public function getDescription(): string
    {
        return '';
    }

    public function up(Schema $schema): void
    {
        // this up() migration is auto-generated, please modify it to your needs
        $this->addSql('ALTER TABLE commentaire DROP COLUMN IF EXISTS updated_at');
        $this->addSql('DROP INDEX IF EXISTS UNIQ_BC91F416989D9B62 ON resource');
        $this->addSql('ALTER TABLE resource DROP COLUMN IF EXISTS slug, DROP COLUMN IF EXISTS updated_at');
    }

    public function down(Schema $schema): void
    {
        // this down() migration is auto-generated, please modify it to your needs
        $this->addSql('ALTER TABLE commentaire ADD updated_at DATETIME DEFAULT NULL');
        $this->addSql('ALTER TABLE resource ADD slug VARCHAR(255) NOT NULL, ADD updated_at DATETIME DEFAULT NULL');
        $this->addSql('CREATE UNIQUE INDEX UNIQ_BC91F416989D9B62 ON resource (slug)');
    }
}
