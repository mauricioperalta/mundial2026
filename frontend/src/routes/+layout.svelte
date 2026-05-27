<script lang="ts">
	import '../app.css';
	import { auth } from '$lib/auth.svelte';
	import { page } from '$app/stores';
	import { goto } from '$app/navigation';
	import Logo from '$lib/components/Logo.svelte';
	import UserMenu from '$lib/components/UserMenu.svelte';
	import NavLinks from '$lib/components/NavLinks.svelte';
	import PwaInstallButton from '$lib/components/PwaInstallButton.svelte';
	import PwaInstallBanner from '$lib/components/PwaInstallBanner.svelte';
	import { serverClock } from '$lib/serverclock.svelte';

	let { children } = $props();

	// Obtiene la hora del servidor (puede ser simulada) para que las comprobaciones
	// de cierre de partidos y el enlace de herramientas de desarrollo sean correctos en toda la app.
	$effect(() => {
		if (auth.isAuthed && !serverClock.loaded) serverClock.refresh();
	});

	// Páginas solo para usuarios cerrados: visibles para usuarios anónimos. Los usuarios ya logueados
	// serán redirigidos al inicio (o a /join si viene una invitación adjunta).
	const authPages = ['/login', '/register', '/forgot-password'];
	let path = $derived($page.url.pathname);
	let isAuthPage = $derived(authPages.includes(path));
	
	// Rutas públicas: cualquiera puede ingresar sin importar su estado de autenticación.
	let isPublic = $derived(
		path.startsWith('/join') ||
			path.startsWith('/confirm-password-reset/')
	);
	
	// No mostrar el diseño de la app en pantallas de autenticación, invitaciones o restablecimiento.
	let chrome = $derived(auth.isAuthed && !isAuthPage && !isPublic);

	// Guardián de rutas SPA.
	$effect(() => {
		const invite = $page.url.searchParams.get('invite');
		if (!auth.isAuthed && !isAuthPage && !isPublic) {
			goto('/login', { replaceState: true });
		}
		// Si ya está logueado, salta las páginas de autenticación. Si llegó mediante una invitación,
		// se lo envía al flujo correspondiente para que se una automáticamente.
		if (auth.isAuthed && isAuthPage) {
			goto(invite ? `/join/${invite}` : '/', { replaceState: true });
		}
	});
</script>

{#if chrome}
	<header class="topbar">
		<Logo />
		<div class="spacer"></div>
		<PwaInstallButton />
		<UserMenu align="right" />
	</header>

	<aside class="siderail">
		<div class="rail-logo"><Logo /></div>
		<NavLinks variant="rail" />
		<div class="spacer"></div>
		<div class="rail-user"><UserMenu align="left" showName up /></div>
	</aside>
{/if}

<PwaInstallBanner />

<main class="app-content" class:has-chrome={chrome}>
	{@render children()}

	{#if chrome && serverClock.isSimulated}
		<div class="clock-banner">
			<span>Reloj virtual activo: <strong>{serverClock.formatted}</strong></span>
			<a href="/dev">Configurar</a>
		</div>
	{/if}
</main>

{#if chrome}
	<nav class="bottomnav">
		<NavLinks variant="tab" />
	</nav>
{/if}

<style>
	/* Los estilos CSS se mantienen exactamente iguales para no alterar el diseño */
	.topbar {
		position: fixed;
		top: 0;
		left: 0;
		right: 0;
		height: var(--header-h);
		background: var(--surface);
		border-bottom: 1px solid var(--border);
		display: flex;
		align-items: center;
		padding: 0 1rem;
		z-index: 50;
	}
	.spacer {
		flex: 1;
	}
	.siderail {
		display: none;
	}
	.bottomnav {
		position: fixed;
		bottom: 0;
		left: 0;
		right: 0;
		height: var(--nav-h);
		background: var(--surface);
		border-top: 1px solid var(--border);
		display: flex;
		z-index: 50;
		padding-bottom: env(safe-area-inset-bottom, 0px);
	}
	.app-content {
		min-height: 100vh;
		display: flex;
		flex-direction: column;
	}
	.app-content.has-chrome {
		padding-top: var(--header-h);
		padding-bottom: calc(var(--nav-h) + env(safe-area-inset-bottom, 0px) + 1.5rem);
	}

	.clock-banner {
		position: fixed;
		bottom: calc(var(--nav-h) + env(safe-area-inset-bottom, 0px));
		left: 0;
		right: 0;
		background: var(--warning-subtle, #fef08a);
		color: var(--warning-text, #854d0e);
		border-top: 1px solid var(--warning-border, #fef08a);
		padding: 0.35rem 1rem;
		font-size: 0.8rem;
		display: flex;
		justify-content: space-between;
		align-items: center;
		z-index: 49;
		box-shadow: 0 -1px 3px rgba(0,0,0,0.05);
	}
	.clock-banner a {
		font-weight: 700;
		text-decoration: underline;
	}

	@media (min-width: 900px) {
		.topbar {
			display: none;
		}
		.bottomnav {
			display: none;
		}
		.siderail {
			display: flex;
			flex-direction: column;
			position: fixed;
			top: 0;
			bottom: 0;
			left: 0;
			width: var(--rail-w);
			background: var(--surface);
			border-right: 1px solid var(--border);
			z-index: 50;
		}
		.rail-logo {
			padding: 1.5rem 1.25rem 2rem;
		}
		.rail-user {
			padding: 1rem 0.75rem;
			border-top: 1px solid var(--border);
		}
		.app-content.has-chrome {
			padding-top: 2rem;
			padding-bottom: 3rem;
			padding-left: var(--rail-w);
		}
		.clock-banner {
			bottom: 0;
			left: var(--rail-w);
		}
	}
</style>
