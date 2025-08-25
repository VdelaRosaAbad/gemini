import setuptools

with open('requirements.txt') as f:
    requirements = f.read().splitlines()

setuptools.setup(
    name='gemini-bq-load',
    version='1.0',
    install_requires=requirements,
    packages=setuptools.find_packages(),
)
