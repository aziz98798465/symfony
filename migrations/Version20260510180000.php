<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;

final class Version20260510180000 extends AbstractMigration
{
    public function getDescription(): string
    {
        return 'Add waiting list fields to reservation_event.';
    }

    public function up(Schema $schema): void
    {
        $this->addSql('ALTER TABLE reservation_event ADD is_waiting_list TINYINT(1) NOT NULL DEFAULT 0, ADD waiting_position INT DEFAULT NULL');
    }

    public function down(Schema $schema): void
    {
        $this->addSql('ALTER TABLE reservation_event DROP is_waiting_list, DROP waiting_position');
    }
}
