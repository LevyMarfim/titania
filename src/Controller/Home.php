<?php

namespace App\Controller;

use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

class Home
{
    #[Route('/')]
    public function home(): Response
    {
        return new Response('<h1>Hello world!</h1>');
    }
}