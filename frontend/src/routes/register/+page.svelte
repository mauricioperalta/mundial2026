<script lang="ts">
	import { auth } from '$lib/auth.svelte';
	import { goto } from '$app/navigation';
	import { page } from '$app/stores';

	// Después de registrarse, reanudar una invitación si venía en la URL.
	let invite = $derived($page.url.searchParams.get('invite'));
	function dest() {
		return invite ? `/join/${invite}` : '/';
	}
	let loginHref = $derived(
		invite ? `/login?invite=${encodeURIComponent(invite)}` : '/login'
	);

	let name = $state('');
	let email = $state('');
	let password = $state('');
	let error = $state('');
	let busy = $state(false);

	async function submit(e: Event) {
		e.preventDefault();
		error = '';
		if (password.length < 8) {
			error = 'La contraseña debe tener al menos 8 caracteres.';
			return;
		}
		busy = true;
		try {
			await auth.register(name, email, password);
			goto(dest());
		} catch (err: unknown) {
			error =
				(err as { message?: string })?.message ??
				'No se pudo crear la cuenta.';
		} finally {
			busy = false;
		}
	}
</script>

<div class="auth">
	<h1>Crear cuenta</h1>
	<p class="muted">Sumate al juego de predicciones del Mundial.</p>

	<form class="card" onsubmit={submit}>
		<div class="field">
			<label for="nm">Nombre de pantalla</label>
			<input id="nm" class="input" bind:value={name} required />
		</div>
		<div class="field">
			<label for="em">Email</label>
			<input
				id="em"
				class="input"
				type="email"
				bind:value={email}
				autocomplete="email"
				required
			/>
		</div>
		<div class="field">
			<label for="pw">Contraseña</label>
			<input
				id="pw"
				class="input"
				type="password"
				bind:value={password}
				autocomplete="new-password"
				required
			/>
		</div>
		{#if error}<p class="error">{error}</p>{/if}
		<button class="btn" disabled={busy}>{busy ? 'Creando…' : 'Registrarme'}</button>
	</form>

	<p class="small muted center">
		¿Ya tenés una cuenta? <a href={loginHref} class="forgot">Iniciá sesión acá</a>
	</p>
</div>

<style>
	/* El bloque CSS se mantiene intacto */
	.auth {
		max-width: 360px;
		margin: 8vh auto 2rem;
		padding: 0 1rem;
	}
	h1 {
		font-family: var(--font-display);
		font-size: 2.2rem;
		text-transform: uppercase;
		margin: 0 0 0.25rem;
		text-align: center;
	}
	p.muted {
		text-align: center;
		margin: 0 0 2rem;
		font-size: 0.95rem;
	}
	.card {
		background: var(--surface);
		border: 1px solid var(--border);
		border-radius: var(--radius);
		padding: 1.5rem;
		display: flex;
		flex-direction: column;
		gap: 1.1rem;
		box-shadow: var(--shadow-sm);
	}
	.error {
		margin: 0;
		background: var(--danger-subtle, #fde8e8);
		color: var(--danger, #e02424);
		border: 1px solid var(--danger-border, #f8b4b4);
		padding: 0.55rem 0.75rem;
		border-radius: var(--radius-sm);
		font-size: 0.85rem;
		font-weight: 500;
	}
	.field {
		display: flex;
		flex-direction: column;
		gap: 0.35rem;
	}
	label {
		font-size: 0.75rem;
		font-weight: 700;
		text-transform: uppercase;
		letter-spacing: 0.05em;
		color: var(--muted);
	}
	.input {
		background: var(--surface-2);
		border: 1px solid var(--border);
		border-radius: var(--radius-sm);
		padding: 0.55rem 0.75rem;
		color: var(--text);
		font-size: 0.95rem;
		width: 100%;
		transition: border-color 0.15s ease;
	}
	input:focus {
		outline: none;
		border-color: var(--accent);
	}
	.forgot {
		color: var(--muted);
		font-weight: 600;
		text-decoration: underline;
		transition: color 0.15s ease;
	}
	.forgot:hover {
		color: var(--accent);
	}
	.center {
		text-align: center;
		margin-top: 1.5rem;
	}
</style>
