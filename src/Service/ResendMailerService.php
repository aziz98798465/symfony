<?php

namespace App\Service;

use Symfony\Contracts\HttpClient\HttpClientInterface;

class ResendMailerService
{
    public function __construct(
        private readonly HttpClientInterface $httpClient,
        private readonly string $resendApiKey,
    ) {
    }

    public function isEnabled(): bool
    {
        return str_starts_with(trim($this->resendApiKey), 're_');
    }

    public function send(string $from, string $to, string $subject, string $html): void
    {
        if (!$this->isEnabled()) {
            throw new \RuntimeException('RESEND_API_KEY is missing or invalid.');
        }

        $response = $this->httpClient->request('POST', 'https://api.resend.com/emails', [
            'headers' => [
                'Authorization' => 'Bearer ' . $this->resendApiKey,
                'Content-Type' => 'application/json',
            ],
            'json' => [
                'from' => $from,
                'to' => [$to],
                'subject' => $subject,
                'html' => $html,
            ],
            'timeout' => 15,
        ]);

        $statusCode = $response->getStatusCode();
        if ($statusCode < 200 || $statusCode >= 300) {
            $body = $response->getContent(false);
            throw new \RuntimeException(sprintf('Resend API failed with HTTP %d: %s', $statusCode, $body));
        }
    }
}
