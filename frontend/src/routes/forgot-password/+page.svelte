<script lang="ts">
	import { auth } from '$lib/auth.svelte';

	let email = $state('');
	let busy = $state(false);
	let sent = $state(false);
	let error = $state('');

	async function submit(e: Event) {
		e.preventDefault();
		error = '';
		busy = true;
		try {
			await auth.requestPasswordReset(email.trim());
			sent = true;
		} catch (err: unknown) {
			error =
				(err as { message?: string })?.message ??
				'No se pudo enviar el correo de restablecimiento.';
		} finally {
			busy = false;
		}
	}
</script>

<div class="auth">
	<h1>Recuperar contraseña</h1>
	<p class="muted">
		Ingresá el correo con el que te registraste y te enviaremos un enlace para restablecerla.
	</p>

	{#if sent}
		<div class="card">
			<p class="ok">Si ese correo está registrado, el enlace ya va en camino.</p>
			<p class="muted switch"><a href="/login">Volver a iniciar sesión</a></p>
		</div>
	{:else}
		<form class="card" onsubmit={submit}>
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
			{#if error}<p class="error">{error}</p>{/if}
			<button class="btn" disabled={busy || !email.trim()}>
				{busy ? 'Enviando…' : 'Enviar enlace'}
			</button>
			<p class="muted switch"><a href="/login">Volver a iniciar sesión</a></p>
		</form>
	{/if}
</div>

<style>
	/* El CSS se mantiene 100% idéntico */
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
	.ok {
		margin: 0;
		background: rgba(22, 163, 74, 0.1);
		color: #16a34a;
		border: 1px solid rgba(22, 163, 74, 0.2);
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
	.switch {
		text-align: center;
		margin: 0.4rem 0 0;
		font-size: 0.9rem;
		font-weight: 600;
		text-decoration: underline;
	}
</style>
